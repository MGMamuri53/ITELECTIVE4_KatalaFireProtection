<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_quotation', function (Blueprint $table) {
            $table->bigIncrements('v_quotationId');

            $table->string('v_quotationNumber', 60)
                ->nullable()
                ->unique();

            $table->unsignedBigInteger('v_serviceRequestId');

            $table->unsignedBigInteger('v_systemDesignId')
                ->nullable();

            $table->dateTime('v_quotationDate')
                ->useCurrent();

            $table->dateTime('v_validUntil')
                ->nullable();

            $table->decimal('v_subtotalAmount', 14, 2)
                ->nullable();

            $table->decimal('v_discountAmount', 14, 2)
                ->default(0.00);

            $table->decimal('v_taxAmount', 14, 2)
                ->default(0.00);

            $table->decimal('v_totalAmount', 14, 2)
                ->nullable();

            $table->text('v_termsAndConditions')
                ->nullable();

            $table->string('v_quotationStatus', 50)
                ->nullable();

            $table->dateTime('v_approvedDate')
                ->nullable();

            $table->text('v_customerRemarks')
                ->nullable();

            $table->dateTime('v_createdAt')
                ->useCurrent();

            $table->dateTime('v_updatedAt')
                ->useCurrent();

            $table->foreign(
                'v_serviceRequestId',
                'fk_quotation_serviceRequest'
            )
                ->references('v_serviceRequestId')
                ->on('tbl_serviceRequest')
                ->onUpdate('cascade')
                ->onDelete('restrict');

            $table->foreign(
                'v_systemDesignId',
                'fk_quotation_systemDesign'
            )
                ->references('v_systemDesignId')
                ->on('tbl_systemDesign')
                ->onUpdate('cascade')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_quotation');
    }
};