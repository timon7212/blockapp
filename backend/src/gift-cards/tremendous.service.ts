import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { AxiosError } from 'axios';

export interface TremendousProduct {
  id: string;
  name: string;
  description: string;
  category: string;
  subcategory?: string;
  currency_codes: string[];
  countries: string[];
  images: { src: string; type: string }[];
  skus: { min: number; max: number }[];
}

export interface TremendousOrder {
  id: string;
  status: string;
  created_at: string;
  reward: {
    id: string;
    delivery: { method: string; link?: string; status: string };
    value: { denomination: number; currency_code: string };
    recipient: { name: string; email: string };
  };
}

@Injectable()
export class TremendousService implements OnModuleInit {
  private readonly logger = new Logger(TremendousService.name);
  private baseUrl: string;
  private apiKey: string;

  constructor(
    private readonly configService: ConfigService,
    private readonly httpService: HttpService,
  ) {}

  onModuleInit() {
    const sandbox = this.configService.get<string>(
      'TREMENDOUS_SANDBOX',
      'true',
    );
    this.baseUrl =
      sandbox === 'false'
        ? 'https://api.tremendous.com/api/v2'
        : 'https://testflight.tremendous.com/api/v2';
    this.apiKey = this.configService.get<string>('TREMENDOUS_API_KEY', '');

    if (!this.apiKey) {
      this.logger.warn(
        'TREMENDOUS_API_KEY is not set — gift card operations will fail',
      );
    }

    this.logger.log(
      `Tremendous API configured: ${sandbox === 'false' ? 'PRODUCTION' : 'SANDBOX'}`,
    );
  }

  private get headers() {
    return {
      Authorization: `Bearer ${this.apiKey}`,
      'Content-Type': 'application/json',
    };
  }

  /**
   * Fetch available gift card products from Tremendous.
   * Optionally filter by country and currency.
   */
  async listProducts(filters?: {
    country?: string;
    currency?: string;
    subcategory?: string;
  }): Promise<TremendousProduct[]> {
    try {
      const params: Record<string, string> = {};
      if (filters?.country) params.country = filters.country;
      if (filters?.currency) params.currency = filters.currency;
      if (filters?.subcategory) params.subcategory = filters.subcategory;

      const { data } = await firstValueFrom(
        this.httpService.get<{ products: TremendousProduct[] }>(
          `${this.baseUrl}/products`,
          { headers: this.headers, params },
        ),
      );

      return data.products.filter(
        (p) => p.category === 'merchant_card',
      );
    } catch (error) {
      this.handleError('listProducts', error);
      return [];
    }
  }

  /**
   * Fetch a single product by its Tremendous ID.
   */
  async getProduct(productId: string): Promise<TremendousProduct | null> {
    try {
      const { data } = await firstValueFrom(
        this.httpService.get<{ product: TremendousProduct }>(
          `${this.baseUrl}/products/${productId}`,
          { headers: this.headers },
        ),
      );
      return data.product;
    } catch (error) {
      this.handleError('getProduct', error);
      return null;
    }
  }

  /**
   * Create a gift card order through Tremendous.
   * Uses LINK delivery so we can retrieve the redemption link programmatically.
   */
  async createOrder(params: {
    productId: string;
    amount: number;
    currency: string;
    recipientName: string;
    recipientEmail: string;
    externalId: string;
  }): Promise<TremendousOrder | null> {
    try {
      const fundingSourceId = this.configService.get<string>(
        'TREMENDOUS_FUNDING_SOURCE_ID',
        'balance',
      );

      const payload = {
        external_id: params.externalId,
        payment: {
          funding_source_id: fundingSourceId,
        },
        reward: {
          products: [params.productId],
          value: {
            denomination: params.amount,
            currency_code: params.currency,
          },
          recipient: {
            name: params.recipientName,
            email: params.recipientEmail,
          },
          delivery: {
            method: 'LINK',
          },
        },
      };

      const { data } = await firstValueFrom(
        this.httpService.post<{ order: TremendousOrder }>(
          `${this.baseUrl}/orders`,
          payload,
          { headers: this.headers },
        ),
      );

      this.logger.log(
        `Order created: ${data.order.id} for product ${params.productId}`,
      );
      return data.order;
    } catch (error) {
      this.handleError('createOrder', error);
      return null;
    }
  }

  /**
   * Retrieve a reward by its Tremendous ID to get delivery link / status.
   */
  async getReward(
    rewardId: string,
  ): Promise<{
    id: string;
    delivery: { method: string; link?: string; status: string };
    value: { denomination: number; currency_code: string };
  } | null> {
    try {
      const { data } = await firstValueFrom(
        this.httpService.get(`${this.baseUrl}/rewards/${rewardId}`, {
          headers: this.headers,
        }),
      );
      return data.reward;
    } catch (error) {
      this.handleError('getReward', error);
      return null;
    }
  }

  private handleError(method: string, error: unknown): void {
    if (error instanceof AxiosError) {
      this.logger.error(
        `Tremendous ${method} failed: ${error.response?.status} ${JSON.stringify(error.response?.data)}`,
      );
    } else {
      this.logger.error(`Tremendous ${method} failed: ${error}`);
    }
  }
}
